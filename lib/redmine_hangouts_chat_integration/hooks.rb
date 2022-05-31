require 'httpclient'

module RedmineHangoutsChatIntegration
  class Hooks < Redmine::Hook::ViewListener
    CHARLIMIT = 1000
    include ApplicationHelper
    include CustomFieldsHelper
    include IssuesHelper

################################################################################
## Hook for issues_new_after_save
################################################################################
    def controller_issues_new_after_save(context={})
      ## check user
      return if is_disabled(User.current)

      ## Get issue
      issue = context[:issue]

      ## Is project disabled
      return if is_project_disabled(issue.project)

      ## Is private issue
      return if issue.is_private

      ## Get issue URL
      issue_url = get_object_url(issue)

      ## Get Webhook URL
      webhook_url = get_webhook_url(issue.project)
      return if webhook_url.nil?

      ## Make Webhook Thread URL
      thread_key = Digest::MD5.hexdigest(issue_url)
      thread_url = webhook_url + "&thread_key=" + thread_key
      return unless thread_url =~ URI::regexp

      ## webhook data
      data = {}

      ## Add issue updated_on
      data['text'] = "*#{l(:field_updated_on)}:#{issue.updated_on}*"

      ## Add issue subject
      subject = issue.subject.gsub(/[　|\s|]+$/, "")
      data['text'] = data['text'] + "\n*#{l(:field_subject)}:<#{issue_url}|[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] #{subject}>*"

      ## Add issue URL
      data['text'] = data['text'] + "\n*URL:* #{issue_url}\n"

      ## Add issue author
      data['text'] = data['text'] + "\n```\n" + l(:text_issue_added, :id => "##{issue.id}", :author => issue.author)

      ## Add issue attributes
      data['text'] = data['text'] + "\n#{''.ljust(37, '-')}\n" + render_email_issue_attributes(issue, User.current)

      ## Add issue descripption
      unless issue.description.blank?
        description = issue.description.truncate(CHARLIMIT, omission: "\n...")
        data['text'] = data['text'] + "\n#{''.ljust(37, '-')}\n[#{l(:field_description)}]\n#{description}"
      end

      ## Add issue attachments
      if issue.attachments.any?
        data['text'] = data['text'] + "\n\n#{l(:label_attachment_plural).ljust(37, '-')}"
        issue.attachments.each do |attachment|
           data['text'] = data['text'] + "\n#{attachment.filename} #{number_to_human_size(attachment.filesize)}"
        end
      end

      ## Add ```
      data['text'] = data['text'] + "\n```"

      ## Send webhook data
      send_webhook_data(thread_url, data)
    end

################################################################################
## Hook for controller_issues_edit_after_save
################################################################################
    def controller_issues_edit_after_save(context={})
      ## check user
      return if is_disabled(User.current)

      ## Get issue and journal
      issue = context[:issue]
      journal = context[:journal]

      ## Is project disabled
      return if is_project_disabled(issue.project)

      ## Is private issue
      return if issue.is_private
      return if journal.private_notes

      ## Get issue URL
      issue_url = get_object_url(issue)

      ## Get Webhook URL
      webhook_url = get_webhook_url(issue.project)
      return if webhook_url.nil?

      ## Make Webhook Thread URL
      thread_key = Digest::MD5.hexdigest(issue_url)
      thread_url = webhook_url + "&thread_key=" + thread_key
      return unless thread_url =~ URI::regexp

      ## webhook data
      data = {}

      ## Add issue updated_on
      data['text'] = "*#{l(:field_updated_on)}:#{issue.updated_on}*"

      ## Add issue subject
      subject = issue.subject.gsub(/[　|\s|]+$/, "")
      data['text'] = data['text'] + "\n*#{l(:field_subject)}:<#{issue_url}|[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] #{subject}>*"

      ## Add issue URL
      data['text'] = data['text'] + "\n*URL:* #{issue_url}\n"

      ## Add issue author
      data['text'] = data['text'] + "\n```\n" + l(:text_issue_updated, :id => "##{issue.id}", :author => journal.user)

      ## Add issue details
      details = details_to_strings(journal.visible_details, true).join("\n")
      unless details.blank?
        data['text'] = data['text'] + "\n#{''.ljust(37, '-')}\n#{details}"
      end

      ## Add issue description
      journal.visible_details.each do |detail|
        if detail.prop_key == 'description'
          description = detail.value.truncate(CHARLIMIT, omission: "\n...")
          data['text'] = data['text'] + "\n#{''.ljust(37, '-')}\n[#{l(:field_description)}]\n#{description}"
          break
        end
      end

      ## Add issue notes
      unless issue.notes.blank?
        notes = issue.notes.truncate(CHARLIMIT, omission: "\n...")
        data['text'] = data['text'] + "\n#{''.ljust(37, '-')}\n[#{l(:field_notes)}]\n#{notes}"
      end

      ## Add ```
      data['text'] = data['text'] + "\n```"

      ## Don't send empty data
      return if details.blank? && issue.notes.blank?

      ## Send webhook data
      send_webhook_data(thread_url, data)
    end

################################################################################
## Hook for controller_issue_relations_new_after_save
################################################################################
    def controller_issue_relations_new_after_save(context={})
      call_hook(:controller_issues_edit_after_save, context)
    end

################################################################################
## Hook for controller_issue_relations_move_after_save
################################################################################
    def controller_issue_relations_move_after_save(context={})
      call_hook(:controller_issues_edit_after_save, context)
    end

################################################################################
## Private Method
################################################################################
private

################################################################################
## Get Redmine Object URL
################################################################################
    def get_object_url(obj)
      routes = Rails.application.routes.url_helpers
      if Setting.host_name.to_s =~ /\A(https?\:\/\/)?(.+?)(\:(\d+))?(\/.+)?\z/i
        host, port, prefix = $2, $4, $5
        routes.url_for(obj.event_url({
          :host => host,
          :protocol => Setting.protocol,
          :port => port,
          :script_name => prefix
        }))
      else
        routes.url_for(obj.event_url({
          :host => Setting.host_name,
          :protocol => Setting.protocol
        }))
      end
    end

################################################################################
## Is Hangouts Chat Disabled
################################################################################
    def is_disabled(user)
      ## check user
      return true if user.nil?

      ## check user custom field
      user_cf = UserCustomField.find_by_name("Hangouts Chat Disabled")
      return true if user_cf.nil?

      ## check user custom value
      user_cv = user.custom_value_for(user_cf)

      ## user_cv is null
      return false if user_cv.nil?

      return true if user_cv.value == '1'

      return false
    end

################################################################################
## Is Hangouts Chat Webhook Disabled
################################################################################
    def is_project_disabled(proj)
      ## check project
      return true if proj.nil?

      ## check proj custom field
      proj_cf = ProjectCustomField.find_by_name("Hangouts Chat Webhook Disabled")
      return true if proj_cf.nil?

      ## check proj custom value
      proj_cv = proj.custom_value_for(proj_cf)

      ## proj_cv is null
      return false if proj_cv.nil?

      return false if proj_cv.value == '1'

      return false
    end

################################################################################
## Get Hangouts Chat Webhook URL
################################################################################
    def get_webhook_url(proj)
      ## used value from this plugin's setting
      if proj.nil?
        return Setting.plugin_redmine_hangouts_chat_integration['hangouts_chat_webhook']
      end

      ## used value from this project's custom field
      proj_cf = ProjectCustomField.find_by_name("Hangouts Chat Webhook")
      unless proj_cf.nil?
        proj_cv = proj.custom_value_for(proj_cf)
        unless proj_cv.nil?
          url = proj_cv.value
          return url if url =~ URI::regexp
        end
      end

      ## used value from parent project's custom field
      return get_webhook_url(proj.parent)
    end

################################################################################
## Send data to Hangouts Chat
################################################################################
    def send_webhook_data(url, data)
      Rails.logger.debug("Webhook URL: #{url}")
      Rails.logger.debug("Webhook Data: #{data.to_json}")

      ## Send data
      begin
        https_proxy = ENV['https_proxy'] || ENV['HTTPS_PROXY']
        client = HTTPClient.new(https_proxy)
        client.ssl_config.cert_store.set_default_paths
        client.ssl_config.ssl_version = :auto
        # client.protocol_retry_count = 10
        # client.debug_dev = Rails.logger
        client.post_async url, {:body => data.to_json, :header => {'Content-Type' => 'application/json'}}
      rescue Exception => e
        Rails.logger.warn("cannot connect to #{url}")
        Rails.logger.warn(e)
      end
    end
  end
end
