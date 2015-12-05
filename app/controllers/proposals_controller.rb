class ProposalsController < ApplicationController

  #Groups create proposals that they submit until their plan is approved

  def create
    @proposal = Proposal.create(params[:proposal])
    flash[:notice] = 'Proposal was successfully created.' if @proposal.save
    render :nothing => true
  end

  def update
    @proposal = Proposal.find(params[:id])
    flash[:notice] = 'Proposal was successfully updated.' if @proposal.update(params[:proposal])
    render :nothing => true
  end

  def destroy
    @proposal = Proposal.find(params[:id])
    @group = @proposal.group
    @proposal.destroy
    respond_with(@group)
  end
end
