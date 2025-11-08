module Api
  module V2
    class ChaseRelationshipsController < ApplicationController
      before_action :authenticate_user!
      before_action :require_current_campaign
      before_action :set_chase_relationship, only: [:show, :update, :destroy]
      before_action :require_gamemaster, only: [:create, :update, :destroy]

      def index
        @chase_relationships = ChaseRelationship.joins(:fight)
                                                 .where(fights: { campaign_id: current_campaign.id })
        
        # Apply filters
        @chase_relationships = @chase_relationships.where(fight_id: params[:fight_id]) if params[:fight_id].present?
        
        if params[:vehicle_id].present?
          @chase_relationships = @chase_relationships.for_vehicle(params[:vehicle_id])
        end
        
        # Default to active relationships unless specified
        if params[:active].present?
          @chase_relationships = @chase_relationships.where(active: ActiveModel::Type::Boolean.new.cast(params[:active]))
        else
          @chase_relationships = @chase_relationships.active
        end
        
        render json: {
          "chase_relationships" => ActiveModelSerializers::SerializableResource.new(
            @chase_relationships,
            each_serializer: ChaseRelationshipSerializer,
            adapter: :attributes
          ).serializable_hash
        }
      end

      def show
        render json: {
          "chase_relationship" => ActiveModelSerializers::SerializableResource.new(
            @chase_relationship,
            serializer: ChaseRelationshipShowSerializer,
            adapter: :attributes
          ).serializable_hash
        }
      end

      def create
        @chase_relationship = ChaseRelationship.new(chase_relationship_params)
        
        # Verify vehicles and fight belong to the campaign
        unless valid_campaign_resources?
          render json: { error: 'Invalid resources for this campaign' }, status: :bad_request
          return
        end
        
        if @chase_relationship.save
          render json: {
            "chase_relationship" => ActiveModelSerializers::SerializableResource.new(
              @chase_relationship,
              serializer: ChaseRelationshipShowSerializer,
              adapter: :attributes
            ).serializable_hash
          }, status: :created
        else
          render json: { errors: @chase_relationship.errors }, status: :unprocessable_content
        end
      end

      def update
        if @chase_relationship.update(update_params)
          render json: {
            "chase_relationship" => ActiveModelSerializers::SerializableResource.new(
              @chase_relationship,
              serializer: ChaseRelationshipShowSerializer,
              adapter: :attributes
            ).serializable_hash
          }
        else
          render json: { errors: @chase_relationship.errors }, status: :unprocessable_content
        end
      end

      def destroy
        # Soft delete - set active to false
        @chase_relationship.update!(active: false)
        head :no_content
      end

      private

      def set_chase_relationship
        @chase_relationship = ChaseRelationship.joins(:fight)
                                               .where(fights: { campaign_id: current_campaign.id })
                                               .find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Chase relationship not found' }, status: :not_found
      end

      def require_gamemaster
        unless current_user.gamemaster?
          render json: { error: 'Only gamemasters can perform this action' }, status: :forbidden
        end
      end

      def chase_relationship_params
        params.require(:chase_relationship).permit(:pursuer_id, :evader_id, :fight_id, :position, :active)
      end

      def update_params
        params.require(:chase_relationship).permit(:position, :active)
      end

      def valid_campaign_resources?
        return false unless @chase_relationship.fight_id.present?
        return false unless @chase_relationship.pursuer_id.present?
        return false unless @chase_relationship.evader_id.present?
        
        fight = Fight.find_by(id: @chase_relationship.fight_id, campaign_id: current_campaign.id)
        pursuer = Vehicle.find_by(id: @chase_relationship.pursuer_id, campaign_id: current_campaign.id)
        evader = Vehicle.find_by(id: @chase_relationship.evader_id, campaign_id: current_campaign.id)
        
        fight.present? && pursuer.present? && evader.present?
      end
    end
  end
end