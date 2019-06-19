class PopulateCustomFields < ActiveRecord::Migration

################################################################################
## Create custom field
################################################################################
  def self.up
    if ProjectCustomField.find_by_name('Hangouts Chat Webhook').nil?
      ProjectCustomField.create(name: 'Hangouts Chat Webhook', field_format: 'string', visible: 0, default_value: '')
    end
    if UserCustomField.find_by_name('Hangouts Chat Disabled').nil?
      UserCustomField.create(name: 'Hangouts Chat Disabled', field_format: 'bool', visible: 0, default_value: 0, is_required: 1)
    end
  end

################################################################################
## Delete custom field
################################################################################
  def self.down
    unless ProjectCustomField.find_by_name('Hangouts Chat Webhook').nil?
      ProjectCustomField.find_by_name('Hangouts Chat Webhook').delete
    end
    unless UserCustomField.find_by_name('Hangouts Chat Disabled').nil?
      UserCustomField.find_by_name('Hangouts Chat Disabled').delete
    end
  end
end
