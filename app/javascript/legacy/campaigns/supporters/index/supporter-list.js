// License: LGPL-3.0-or-later
const h = require('virtual-dom/h')
const thunk = require('vdom-thunk')


const metrics = require('./metrics')
const meta = require('./meta')
const supporterTable = require('./supporter-table.js')

var $ = {
	showMore: supporterTable.$streams.showMore,
	searches: meta.$streams.searches,
}

const root = state =>
	h('div', [
		h('section.table-meta', thunk(meta.root, state)),
		h('section.metrics.container', thunk(metrics.root, state.get('gift_levels'))),
		h('hr'),
		h('section.container', thunk(supporterTable.root, state)),
		h('hr'),
	])

// Table meta for the supporter listing under Campaigns

module.exports = {root: root, $streams: $}

