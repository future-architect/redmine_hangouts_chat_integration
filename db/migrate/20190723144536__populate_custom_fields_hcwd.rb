class PopulateCustomFieldsHcwd < ActiveRecord::Migration

################################################################################
## Create custom field
################################################################################
  def self.up
    if ProjectCustomField.find_by_name('Hangouts Chat Webhook Disabled').nil?
      ProjectCustomField.create(name: 'Hangouts Chat Webhook Disabled', field_format: 'bool', visible: 0, default_value: 0, is_required: 1)
    end
  end

################################################################################
## Delete custom field
################################################################################
  def self.down
    unless ProjectCustomField.find_by_name('Hangouts Chat Webhook Disabled').nil?
      ProjectCustomField.find_by_name('Hangouts Chat Webhook Disabled').delete
    end
  end
end
