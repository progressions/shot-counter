require 'rails_helper'

RSpec.describe Api::V2::ChaseRelationshipsController, type: :controller do
  include Devise::Test::ControllerHelpers
  let!(:user) { User.create!(email: "test@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now, password: "password123") }
  let!(:gamemaster) { User.create!(email: "gm@example.com", first_name: "Game", last_name: "Master", confirmed_at: Time.now, password: "password123", gamemaster: true) }
  let!(:campaign) { gamemaster.campaigns.create!(name: "Test Campaign") }
  let!(:fight) { campaign.fights.create!(name: "Chase Scene") }
  let!(:pursuer) { campaign.vehicles.create!(name: "Police Car") }
  let!(:evader) { campaign.vehicles.create!(name: "Getaway Van") }
  let!(:other_vehicle) { campaign.vehicles.create!(name: "Motorcycle") }
  
  before do
    gamemaster.campaign_ids = [campaign.id]
    gamemaster.save!
    user.campaign_ids = [campaign.id]
    user.save!
    # Set current campaign for gamemaster and user
    allow_any_instance_of(ApplicationController).to receive(:current_campaign).and_return(campaign)
  end

  describe 'GET #index' do
    let!(:relationship1) { ChaseRelationship.create!(pursuer: pursuer, evader: evader, fight: fight) }
    let!(:relationship2) { ChaseRelationship.create!(pursuer: other_vehicle, evader: pursuer, fight: fight) }
    let!(:inactive_relationship) { ChaseRelationship.create!(pursuer: pursuer, evader: other_vehicle, fight: fight, active: false) }

    context 'when authenticated' do
      before do
        sign_in gamemaster
      end

      it 'returns all active chase relationships' do
        get :index
        
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['chase_relationships'].length).to eq(2)
        expect(json['chase_relationships'].map { |r| r['id'] }).to match_array([relationship1.id, relationship2.id])
      end

      it 'filters by fight_id when provided' do
        other_fight = campaign.fights.create!(name: "Other Chase")
        other_relationship = ChaseRelationship.create!(pursuer: pursuer, evader: evader, fight: other_fight)
        
        get :index, params: { fight_id: fight.id }
        
        json = JSON.parse(response.body)
        expect(json['chase_relationships'].length).to eq(2)
        expect(json['chase_relationships'].map { |r| r['id'] }).not_to include(other_relationship.id)
      end

      it 'filters by vehicle_id when provided' do
        get :index, params: { vehicle_id: pursuer.id }
        
        json = JSON.parse(response.body)
        expect(json['chase_relationships'].length).to eq(2)
        expect(json['chase_relationships'].map { |r| r['id'] }).to match_array([relationship1.id, relationship2.id])
      end

      it 'includes inactive when active=false' do
        get :index, params: { active: false }
        
        json = JSON.parse(response.body)
        expect(json['chase_relationships'].map { |r| r['id'] }).to include(inactive_relationship.id)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    let!(:relationship) { ChaseRelationship.create!(pursuer: pursuer, evader: evader, fight: fight) }

    context 'when authenticated' do
      before do
        sign_in user
      end

      it 'returns the chase relationship with vehicle details' do
        get :show, params: { id: relationship.id }
        
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['chase_relationship']['id']).to eq(relationship.id)
        expect(json['chase_relationship']['position']).to eq('far')
        expect(json['chase_relationship']['pursuer']['id']).to eq(pursuer.id)
        expect(json['chase_relationship']['evader']['id']).to eq(evader.id)
      end

      it 'returns not found for non-existent relationship' do
        get :show, params: { id: 'non-existent' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    context 'when authenticated as gamemaster' do
      before do
        sign_in gamemaster
      end

      it 'creates a new chase relationship' do
        expect {
          post :create, params: { 
            chase_relationship: {
              pursuer_id: pursuer.id,
              evader_id: evader.id,
              fight_id: fight.id,
              position: 'near'
            }
          }
        }.to change(ChaseRelationship, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['chase_relationship']['position']).to eq('near')
      end

      it 'returns error for invalid parameters' do
        post :create, params: { 
          chase_relationship: {
            pursuer_id: pursuer.id,
            evader_id: pursuer.id, # Same vehicle
            fight_id: fight.id
          }
        }
        
        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('evader_id')
      end

      it 'returns error for duplicate active relationship' do
        ChaseRelationship.create!(pursuer: pursuer, evader: evader, fight: fight)
        
        post :create, params: { 
          chase_relationship: {
            pursuer_id: pursuer.id,
            evader_id: evader.id,
            fight_id: fight.id
          }
        }
        
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when authenticated as regular user' do
      before do
        sign_in user
      end

      it 'returns forbidden' do
        post :create, params: { 
          chase_relationship: {
            pursuer_id: pursuer.id,
            evader_id: evader.id,
            fight_id: fight.id
          }
        }
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH #update' do
    let!(:relationship) { ChaseRelationship.create!(pursuer: pursuer, evader: evader, fight: fight, position: 'far') }

    context 'when authenticated as gamemaster' do
      before do
        sign_in gamemaster
      end

      it 'updates the chase relationship' do
        patch :update, params: { 
          id: relationship.id,
          chase_relationship: {
            position: 'near'
          }
        }
        
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['chase_relationship']['position']).to eq('near')
        
        relationship.reload
        expect(relationship.position).to eq('near')
      end

      it 'can deactivate a relationship' do
        patch :update, params: { 
          id: relationship.id,
          chase_relationship: {
            active: false
          }
        }
        
        expect(response).to have_http_status(:success)
        relationship.reload
        expect(relationship.active).to be false
      end

      it 'returns error for invalid position' do
        patch :update, params: { 
          campaign_id: campaign.id,
          id: relationship.id,
          chase_relationship: {
            position: 'invalid'
          }
        }
        
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:relationship) { ChaseRelationship.create!(pursuer: pursuer, evader: evader, fight: fight) }

    context 'when authenticated as gamemaster' do
      before do
        sign_in gamemaster
      end

      it 'soft deletes the relationship (sets active to false)' do
        expect {
          delete :destroy, params: { id: relationship.id }
        }.not_to change(ChaseRelationship, :count)
        
        expect(response).to have_http_status(:no_content)
        
        relationship.reload
        expect(relationship.active).to be false
      end
    end

    context 'when authenticated as regular user' do
      before do
        sign_in user
      end

      it 'returns forbidden' do
        delete :destroy, params: { id: relationship.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end