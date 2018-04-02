class SampleSubmissionsController < ApplicationController
  before_action :set_sample_submission, only: [:show, :edit, :update, :destroy]
  before_action :authorize

  # Allow student enrolled in that assignment to view sample submissions
  # Allow everyone else to view it
  def action_allowed?
    return true if ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator'].include? current_role_name
    @teams = TeamsUser.where(user_id: current_user.try(:id))
    @teams.each do |team|
      if Team.where(id: team.team_id).first.parent_id == sample_submission_params[:id].to_i
        return true
      end
    end
    false
  end

  # GET /sample_submissions
  def index
    @assignment_teams = AssignmentTeam.where(parent_id: sample_submission_params[:id], make_public: true)
    @assignment = Assignment.where(id: sample_submission_params[:id]).first
    @assignment_teams_professor = AssignmentTeam.where(parent_id: @assignment.sample_assignment_id, make_public: true)
    @assignment_due_date = DueDate.where(parent_id: @assignment.id).last
    @assignment_due_date = @assignment_due_date.due_at unless @assignment_due_date.nil?
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_sample_submission
    @sample_submission = SampleSubmission.find(params[:id])
  end

  # Only allow a trusted parameter "white index" through.
  def sample_submission_params
    params.permit(:id)
  end
end