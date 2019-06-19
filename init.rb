require_dependency 'redmine_hangouts_chat_integration/hooks'
require_dependency 'redmine_hangouts_chat_integration/issue_relations_controller_patch'

################################################################################
## Register Plugin
################################################################################
Redmine::Plugin.register :redmine_hangouts_chat_integration do
  name 'Redmine Hangouts Chat Integration plugin'
  author 'Komatsu Yuji'
  description 'This is a plugin for Redmine Google Hangouts Chat Integration'
  version '0.0.4'
  url 'https://www.future.co.jp/'
  author_url 'https://www.future.co.jp/'

  settings :default => {}, :partial => 'settings/hangouts_chat_integration_settings'

end
