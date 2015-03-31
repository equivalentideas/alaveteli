# app/controllers/widget_controller.rb:
# Handle widgets, if enabled
#
# Copyright (c) 2014 UK Citizens Online Democracy. All rights reserved.
# Email: hello@mysociety.org; WWW: http://www.mysociety.org/

class WidgetsController < ApplicationController

    require 'securerandom'

    before_filter :find_info_request, :check_widget_config, :check_prominence
    skip_before_filter :set_x_frame_options_header, :only => [:show]

    def show
        medium_cache
        @track_thing = TrackThing.create_track_for_request(@info_request)
        @status = @info_request.calculate_status
        unless @user or cookies[:widget_vote]
          cookies.permanent[:widget_vote] = SecureRandom.hex(10)
        end
        render :action => 'show', :layout => false
    end

    def new
        long_cache
    end

    # Track interest in a request from a non-logged in user
    def update
        if not @user and cookies[:widget_vote]
            wv = @info_request.widget_votes.where(:cookie => cookies[:widget_vote]).first_or_create
        end

        track_thing = TrackThing.create_track_for_request(@info_request)
        redirect_to do_track_path(track_thing), status => :temporary_redirect
    end

    private

    def find_info_request
        @info_request = InfoRequest.find(params[:request_id])
    end

    def check_widget_config
        unless AlaveteliConfiguration::widget_page
            raise ActiveRecord::RecordNotFound.new("Page not enabled")
        end
    end

    def check_prominence
        unless @info_request.prominence == 'normal'
            render :nothing => true, :status => :forbidden
        end
    end

end
