# Redmine Google Hangouts Chat Plugin

For Redmine 2.x.x or Redmine 3.x.x.

### Plugin installation

1.  Copy the plugin directory into the $REDMINE_ROOT/plugins directory. Please
    note that plugin's folder name should be "redmine_hangouts_chat_integration". 

2.  Install 'httpclient'

    e.g. bundle install

3.  Do migration task.

    e.g. RAILS_ENV=production rake redmine:plugins:migrate

4.  (Re)Start Redmine.

### Uninstall

Try this:

*  RAILS_ENV=production rake db:migrate_plugins NAME=redmine_hangouts_chat_integration VERSION=0

### Settings

#### Use webhook in each project

1.  Login redmine used the project admin account.

2.  Open this project "Settings" -> "Information" page.

3.  Paste the google hangouts chat webhook URL into "Hangouts Chat Webhook".

4.  Save this project settings.

#### Use webhook in all project

1.  Login redmine used redmine admin account.

2.  Open top menu "Administration" -> "Plugins" -> "Redmine Hangouts Chat Integration plugin" -> "Configure" page

3.  Paste the google hangouts chat webhook URL into "Webhook".

4.  Apply this configure.

### Disable specified accout

1.  Login redmine used yourself accout.

2.  Open top right menu "My account" page.

3.  Switch "Hangouts Chat Disable" to "Yes"

### How to use

1.  Create a new issue, and your chat room will get a message from redmine.

2.  Edit any issue, and your chat room will get a message from redmine.