# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module InsertTracking
  def self.create(params)
    result = {}

    result['tracking'] = Qx.insert_into(:trackings)
                           .values(
                             utm_campaign: params[:utm_campaign],
                             utm_content: params[:utm_content],
                             utm_medium: params[:utm_medium],
                             utm_source: params[:utm_source],
                             donation_id: params[:donation_id]
                           )
                           .timestamps
                           .returning('*')
                           .execute.first

    { status: 200, json: result }
  end
end
