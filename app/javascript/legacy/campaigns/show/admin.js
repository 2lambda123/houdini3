// License: LGPL-3.0-or-later
require('../../common/pikaday-timepicker')
require('../../common/restful_resource')
const request = require('../../common/client').default
const formatErr = require('../../common/format_response_error').default
require('../../common/image_uploader')
require('./tour')
const dupeIt = require('../../components/duplicate_fundraiser')
const {
	nonprofitCampaignPath,
	nonprofitCampaignsPath
} = require('../../../routes')

dupeIt(nonprofitCampaignsPath(app.nonprofit_id), app.campaign_id)

const url = nonprofitCampaignPath(app.nonprofit_id, app.campaign_id);
const create_supporter = require('../../nonprofits/supporters/create').default
const create_offline_donation = require('../../donations/create_offline').default

require('../../components/ajax/toggle_soft_delete')(url, 'campaign')

// Initialize the froala wysiwyg
const editable = require('../../common/editable')
if (app.is_parent_campaign) {
  editable($('#js-campaignBody'), {
    sticky: true,
    placeholder: "Add your campaign's story here. We strongly recommend that this section is filled out with at least 250 words. It will be saved automatically as you type. You can add images, videos and custom HTML too."
  })
}

editable($('#js-customReceipt'), {
  button: ["bold", "italic", "formatBlock", "align", "createLink",
  		"insertImage", "insertUnorderedList", "insertOrderedList",
  		"undo", "redo", "insert_donate_button", "html"]
	, placeholder: "Add optional message here. It will be saved automatically as you type."
})




appl.def('remove_banner_image', function() {
	const url = nonprofitCampaignPath(app.nonprofit_id, app.campaign_id);
	const notification = 'Removing banner image...'
	const payload = {remove_banner_image : true}
	appl.remove_image(url, 'campaign', notification, payload)
})

appl.def('remove_background_image', function() {
	const url = nonprofitCampaignPath(app.nonprofit_id, app.campaign_id);
	const notification = 'Removing background image...'
	const payload = {remove_background_image : true}
	appl.remove_image(url, 'campaign', notification, payload)
})

appl.def('count_story_words', function() {
	const wysiwyg = document.querySelector(".editable")
	appl.def('has_story', wysiwyg.textContent.split(' ').length > 60)
})

appl.def('highlight_body', function(){
	appl.def('body_is_highlighted', true)
	appl.close_modal()
})

appl.count_story_words(document.querySelector('.campaign-body'))

appl.def('track_launch', function() {
	window.location.reload()
})

appl.def('create_offline_donation', function(data, el) {
	create_supporter({supporter: data.supporter}, createSupporterUI)
		.then(function(resp) {
			data.supporter_id = resp.body.id
      delete data.supporter
			return create_offline_donation(data, createDonationUI)
		}).then(function(el){
			appl.ajax_metrics.index()
			appl.prev_elem(el).reset()
		})
})


const createSupporterUI = {
	start: function() {
		appl.is_loading()
	},
	success: function() {
		return this
	},
	fail: function(msg) {
		appl.def('error', formatErr(msg))
		appl.not_loading()
	}
}

const createDonationUI = {
	start: function() { },
	success: function(resp) {
		appl.not_loading()
		appl.close_modal()
		appl.notify('Campaign Donation Saved!')
	},
	fail: function(msg){
		appl.def('error', formatErr(msg))
		appl.not_loading()
	}
}

if(app.vimeo_id) {
  request.get('http://vimeo.com/api/v2/video/' + app.vimeo_id  + '.json')
    .end(function(_err, resp){
      appl.def('vimeo_image_url', "background-image:url('" + resp.body[0].thumbnail_small + "')")
    })
}
