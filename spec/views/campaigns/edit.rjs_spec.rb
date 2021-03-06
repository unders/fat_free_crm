require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
 
describe "/campaigns/edit.js.rjs" do
  include CampaignsHelper
  
  before(:each) do
    login_and_assign
    assigns[:campaign] = Factory(:campaign, :id => 42, :user => @current_user)
    assigns[:users] = [ @current_user ]
  end

  it "cancel from campaign index page: should replace [Edit Campaign] form with campaign partial" do
    params[:cancel] = "true"
    
    render "campaigns/edit.js.rjs"
    response.should have_rjs("campaign_42") do |rjs|
      with_tag("li[id=campaign_42]")
    end
  end

  it "cancel from campaign landing page: should hide [Edit Campaign] form" do
    request.env["HTTP_REFERER"] = "http://localhost/campaigns/123"
    params[:cancel] = "true"
    
    render "campaigns/edit.js.rjs"
    response.should include_text('crm.flip_form("edit_campaign"')
  end

  it "edit: should hide previously open [Edit Campaign] for and replace it with campaign partial" do
    params[:cancel] = nil
    assigns[:previous] = Factory(:campaign, :id => 41, :user => @current_user)
    
    render "campaigns/edit.js.rjs"
    response.should have_rjs("campaign_41") do |rjs|
      with_tag("li[id=campaign_41]")
    end
  end

  it "edit: should remove previously open [Edit Campaign] if it's no longer available" do
    params[:cancel] = nil
    assigns[:previous] = 41

    render "campaigns/edit.js.rjs"
    response.should include_text(%Q/crm.flick("campaign_41", "remove");/)
  end
  
  it "edit from campaigns index page: should turn off highlight and replace current campaign with [Edit Campaign] form" do
    params[:cancel] = nil
    
    render "campaigns/edit.js.rjs"
    response.should include_text('crm.highlight_off("campaign_42");')
    response.should have_rjs("campaign_42") do |rjs|
      with_tag("form[class=edit_campaign]")
    end
  end
  
  it "edit from campaign landing page: should show [Edit Campaign] form" do
    params[:cancel] = "false"
    
    render "campaigns/edit.js.rjs"
    response.should have_rjs("edit_campaign") do |rjs|
      with_tag("form[class=edit_campaign]")
    end
    response.should include_text('crm.flip_form("edit_campaign"')
  end
  
  it "should call JavaScript to set up popup Calendar" do
    params[:cancel] = nil

    render "campaigns/edit.js.rjs"
    response.should include_text('crm.date_select_popup("campaign_starts_on")')
    response.should include_text('crm.date_select_popup("campaign_ends_on")')
    response.should include_text('$("campaign_name").focus()')
  end

end
