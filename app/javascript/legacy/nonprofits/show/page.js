// License: LGPL-3.0-or-later
if (app.nonprofit.brand_color) {
	require('../../components/branded_fundraising').default
}

require('../../common/image_uploader')
require('../../components/fundraising/add_header_image').default
const {profileTodosNonprofitPath} = require('../../../routes');
if(app.current_user) {
	require('../../campaigns/new/wizard')
	require('../../events/new/wizard')
}

if(app.current_nonprofit_user) {
	const editable = require('../../common/editable')
	editable($('.editable'), {
    placeholder: "Enter your nonprofit's story and impact here. We strongly recommend that this section is filled out with at least 250 words. It will automatically save as you type.", 
    sticky: $('.editable').length > 0
  })
	require('./tour')
	require('../../supporters/info-card')

	appl.def('todos_action', profileTodosNonprofitPath(app.nonprofit_id))
	const todos = require('../../components/todos').default
	todos(function(data) {
		appl.def('todos.items', [
			{text: "Add logo", done: data['has_logo'], modal_id: 'settingsModal' },
			{text: "Add header image", done: data['has_background'], modal_id: 'uploadBackgroundImage' },
			{text: "Add summary", done: data['has_summary'], modal_id: 'settingsModal' },
			{text: "Add images", done: data['has_image'], modal_id: 'uploadCarouselImages' },
			{text: "Add highlights", done: data['has_highlight'], modal_id: 'settingsModal' },
			{text: "Add services and impact", done: data['has_services'], link: '#js-servicesAndImpact' }
		])
	})
}

// -- Flimflam

const snabbdom = require('snabbdom')
const h = require('snabbdom/h')
const flyd = require('flyd')
const R = require('ramda')
const donateWiz = require('../../nonprofits/donate/wizard')
const modal = require('ff-core/modal')
const render = require('ff-core/render')
const branding = require('../../components/nonprofit-branding').default

function init() {
  const state = {}
  state.donateWiz = donateWiz.init(flyd.stream({}))
  state.modalID$ = flyd.stream()
  return state
}

function view(state) {
  return h('section.box-r', [
    h('aside', [
      h('a.button--jumbo u-width--full', {
        style: {background: branding.dark}
      , on: {click: [state.modalID$, 'donationModal']}
      }, [
        `Donate to ${app.nonprofit.name}`
      ])
    , h('div.donationModal', [
        modal({
          thisID: 'donationModal'
        , id$: state.modalID$
        , body: donateWiz.view(state.donateWiz)
        // , notCloseable: state.donateWiz.paymentStep.cardForm.loading$()
        })
      ])
    ])
  ])
}


// -- Render

const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])
const container = document.querySelector('.ff-container')
const state = init()
render({container, view, patch, state})

