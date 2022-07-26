// License: LGPL-3.0-or-later
// this will be generated by some route generator in future but for now, we'll handcode it.

export default {
	nonprofitsRecurringDonations: {
		path: (props: {id:string}):string => {
			return `/nonprofits/${props.id}/recurring_donations`;
		},

		url: (props: {id:string}):string => {
			return `/nonprofits/${props.id}/recurring_donations`;
		},

	},
};