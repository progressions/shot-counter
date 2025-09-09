# CombatActionService

## Overview

The `CombatActionService` is the core of the combat system in the `shot-server`. It is responsible for processing a batch of updates to characters and vehicles within a single combat encounter. The service is designed to be robust, transactional, and efficient, using a service-oriented architecture to separate concerns.

## The Flow of a Combat Action

1.  **Client-Side (`shot-client-next`):**
    *   An action is initiated in the UI (e.g., a character attacks, uses an ability, or takes damage).
    *   The client constructs a payload, which is an array of `character_updates` objects. Each object in this array represents a single change to a character or vehicle in the fight.
    *   This payload is sent to the server via an API call to the `apply_combat_action` endpoint in the `EncountersController`.

2.  **Controller (`EncountersController`):
    *   The `apply_combat_action` action receives the request.
    *   It uses strong parameters (`combat_action_params`) to whitelist the allowed attributes for the `character_updates`. This is a security measure to prevent mass-assignment vulnerabilities.
    *   The controller then passes the `fight` object and the sanitized `character_updates` array to the `CombatActionService`.

3.  **Service (`CombatActionService`):
    *   This is where the core business logic of the combat system resides.
    *   **Transaction:** All updates are wrapped in a database transaction (`ActiveRecord::Base.transaction`). This ensures that all changes are applied successfully, or none are. If any part of the process fails, the entire transaction is rolled back, preventing inconsistent data.
    *   **Broadcast Control:** To avoid overwhelming the client with many small updates, WebSocket broadcasts are temporarily disabled at the start of the transaction.
    *   **Applying Updates:** The service iterates through each `update` hash in the `character_updates` array and applies the changes. It can handle a wide variety of updates, including:
        *   Changing a character's shot value (`shot` or `shot_cost`).
        *   Modifying `action_values` (e.g., Wounds, Fortune).
        *   Adding or removing status effects (`add_status`, `remove_status`).
        *   Updating impairments, defense, and other attributes.
        *   Logging the action as a `FightEvent`.
    *   **PC vs. NPC Logic:** The service has distinct logic for Player Characters (PCs) versus Non-Player Characters (NPCs) and vehicles.
        *   **PC updates** are generally applied to the persistent `Character` record.
        *   **NPC and vehicle updates** are applied to the `Shot` record, which is specific to the current fight.
    *   **Single Broadcast:** After the transaction successfully completes, WebSocket broadcasts are re-enabled, and a single `broadcast_encounter_update!` is triggered on the `fight` object. This sends one comprehensive update to all connected clients, ensuring their view of the encounter is synchronized with the server.

## Key Features

*   **Service-Oriented:** The logic is encapsulated in a dedicated service, making it easy to understand, test, and reuse.
*   **Transactional:** The use of a database transaction guarantees data integrity.
*   **Efficient:** Disabling and then batching WebSocket broadcasts is an important optimization for real-time applications.
*   **Secure:** Strong parameters in the controller protect against malicious input.
*   **Flexible:** The system can handle a wide variety of combat actions through a single, unified interface.
