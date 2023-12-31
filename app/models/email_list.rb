# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class EmailList < ApplicationRecord
  # :list_name,
  # :mailchimp_list_id,
  # :nonprofit,
  # :tag_definition
  belongs_to :nonprofit
  belongs_to :tag_definition
end
