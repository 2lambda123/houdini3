// License: LGPL-3.0-or-later
require('../common/restful_resource')
const {
	nonprofitCampaignPath,
} = require('../../routes');

appl.def('gift_options', {
	resource_name: 'campaign_gift_options',
	path_prefix:nonprofitCampaignPath(app.nonprofit_id, app.campaign_id) + '/',
})

appl.def('ajax_gift_options.index', function() {
	appl.ajax.index('gift_options').then(function(resp) {
		const data = resp.body.data
		appl.def('gift_options.data', supplementData(data))
		checkForQuantity(data)
	})
})

function supplementData(data) {
	return data.map(function(x) {
		if(x.quantity) {
			const remaining =  x.quantity - x.total_gifts
			x.remaining = remaining > 0 ? remaining : 0
		}
		return x
	})
}

function checkForQuantity(data) {
	data.forEach(function(x){
		if(x.quantity) {
			appl.def('gift_options.has_any_quantities', true) 
		}
	})
}
