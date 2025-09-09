# Refactoring Plan: Unifying the Combat Action API

This document outlines a refactoring plan to unify the combat action API around a declarative ("this is the new value") paradigm.

## Analysis: Where the Paradigm is Broken

The primary deviation from the declarative model is the concept of sending a "cost" to the backend and letting the server calculate the new value. This happens in two main ways:

1.  **`shot_cost` in `applyCombatAction`:** The `CombatActionService` on the backend has a specific block to handle a `shot_cost` parameter, which calculates the new shot value. This is an imperative instruction.
2.  **`spendShots` Endpoint:** The `Actions.tsx` component uses a completely separate, imperative endpoint (`client.spendShots`) to handle the simple action of spending shots.

The goal is to eliminate these imperative pathways and use the declarative `applyCombatAction` for all shot changes.

---

## The Refactoring Plan

This plan is broken into two parts: first, refactoring the `applyCombatAction` payload, and second, deprecating the `spendShots` endpoint.

### Part 1: Unify the `applyCombatAction` Payload

The goal here is to ensure that any call to `applyCombatAction` *only* sends the final, calculated `shot` value, not the cost.

**1. Backend Change (`shot-server`):**

*   **File:** `app/services/combat_action_service.rb`
*   **Action:** Remove the imperative `shot_cost` logic. The existing logic for handling a declarative `shot` update is already correct and sufficient.

    ```diff
    --- a/app/services/combat_action_service.rb
    +++ b/app/services/combat_action_service.rb
    @@ -30,16 +30,6 @@
     entity = shot.character || shot.vehicle
     entity_name = entity&.name || "Unknown"
 
    -    # Handle shot cost if provided (character spending shots for an action)
    -    if update[:shot_cost].present?
    -      shot_cost = update[:shot_cost].to_i
    -      # Ensure we don't go below -10 (the minimum allowed shot value)
    -      new_shot_value = [shot.shot - shot_cost, -10].max
    -      actual_cost = shot.shot - new_shot_value
    -      Rails.logger.info "🎲 #{entity_name} spending #{actual_cost} shots (#{shot.shot} -> #{new_shot_value})"
    -      shot.shot = new_shot_value
    -      shot.save!
    -    end
    -
     # Update shot position if provided (direct position update, not cost)
     if update[:shot].present? && shot.shot != update[:shot]
       Rails.logger.info "🎯 Moving #{entity_name} from shot #{shot.shot} to #{update[:shot]}"
    ```

**2. Frontend Changes (`shot-client-next`):**

The frontend already calculates the new shot value in most places. The only change is to stop sending the redundant `shot_cost` key in the event details, which could be confusing.

*   **File:** `src/components/encounters/CheeseItPanel.tsx`
    *   **Action:** In the `handleCheeseIt` function, remove the `shot_cost` key from the `event.details` object.

*   **File:** `src/components/encounters/SpeedCheckPanel.tsx`
    *   **Action:** In the `handlePreventEscape` function, remove the `shot_cost` key from the `event.details` object in all the `characterUpdates`.

*   **File:** `src/components/encounters/attacks/combatHandlers.ts`
    *   **Action:** For consistency, rename the `shot_cost` parameter in the `event.details` of the `createAttackerUpdate` and `createWoundUpdate` functions to something like `action_shot_cost`. This makes it clear it's for informational/logging purposes and not for calculation by the backend. This is an optional but recommended change for clarity.

### Part 2: Deprecate the `spendShots` Endpoint

This is the most significant part of the refactor. We will replace the specific `spendShots` call with a declarative call to the now-unified `applyCombatAction`.

**1. Frontend Changes (`shot-client-next`):**

*   **File:** `src/contexts/EncounterContext.tsx`
    *   **Action:** Remove the `spendShots` method from the `EncounterClient` and its implementation. We will replace its usage directly in `Actions.tsx`.

*   **File:** `src/components/encounters/Actions.tsx`
    *   **Action:** Modify the `handleAct` function. Instead of calling `ec.spendShots`, it will now construct a declarative payload and call `client.applyCombatAction`.

    ```typescript
    // src/components/encounters/Actions.tsx

    // ... imports
    import { useClient, useEncounter } from "@/contexts"; // Make sure useClient is imported

    // ... inside the Actions component
    const { client } = useClient(); // Get the client from the context
    const { encounter } = useEncounter();

    const handleAct = async () => {
      if (!entity || !encounter) return;

      const currentShot = entity.shot ?? 0; // Get the current shot
      const newShot = currentShot - shotCost; // Calculate the new shot value

      const characterUpdate = {
        shot_id: entity.shot_id,
        character_id: entity.id,
        shot: newShot,
        event: {
          type: "spend_shots",
          description: `${entity.name} spent ${shotCost} ${shotCost === 1 ? "shot" : "shots"}`,
          details: {
            character_id: entity.id,
            shots_spent: shotCost,
            from_shot: currentShot,
            to_shot: newShot,
          },
        },
      };

      try {
        await client.applyCombatAction(encounter, [characterUpdate]);
        toastSuccess(`${entity.name} spent ${shotCost} ${shotCost === 1 ? "shot" : "shots"}`);
      } catch (error) {
        toastError("Failed to spend shots");
        console.error("Error spending shots:", error);
      }
    };
    ```

*   **File:** `src/lib/client/Client.ts` (or wherever `client.spendShots` is defined)
    *   **Action:** Delete the `spendShots` method from the client.

**2. Backend Changes (`shot-server`):**

*   **File:** `config/routes.rb`
    *   **Action:** Find the route that maps to the `spend_shots` action in the `encounters_controller` and delete it. It will look something like `post 'spend_shots', on: :member`.

*   **File:** `app/controllers/api/v2/encounters_controller.rb`
    *   **Action:** Delete the entire `act` method (which was handling the `spendShots` logic). The `apply_combat_action` method will now handle this case.

### Summary of the Result

By completing this refactoring, you will have a single, unified, and declarative API for all combat actions.

*   **One Endpoint:** All character updates in a fight will go through the `apply_combat_action` endpoint.
*   **Declarative Payloads:** The client will always be responsible for calculating the final state of an attribute.
*   **Simplified Backend:** The backend logic will be simpler and more consistent, with no need to interpret imperative "cost" parameters.
*   **Improved Maintainability:** The entire system will be easier to understand, debug, and extend in the future.
