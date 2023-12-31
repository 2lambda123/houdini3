// License: LGPL-3.0-or-later
// super-agent with default json and csrf wrappers
// Also has a Promise api ('.then' and '.catch') rather than the default '.end'

import request, { CallbackHandler} from './client';
import type { SuperAgentRequest, Response } from 'superagent';

type SuperAgentRequestWithPerform = SuperAgentRequest & { perform: () => Promise<Response> };

function convert_to_promise(req: SuperAgentRequest): SuperAgentRequestWithPerform {
	const anyReq = req as unknown as SuperAgentRequestWithPerform;
	anyReq.perform = function () {
		return new Promise(function (resolve, reject) {
			req.end(function (_err, resp) {
				if (resp && resp.ok) { resolve(resp); }
				else { reject(resp); }
			});
		});
	};
	return anyReq;
}


const wrapper = {
	post: function (path:string,	callback?:CallbackHandler	): SuperAgentRequestWithPerform {
		return convert_to_promise(request.post(path, callback));
	},

	put: function (path:string, callback?:CallbackHandler): SuperAgentRequestWithPerform {
		return convert_to_promise(request.put(path, callback));
	},

	del: function (path:string, callback?:CallbackHandler): SuperAgentRequestWithPerform {
		return convert_to_promise(request.del(path, callback));
	},

	get: function (path:string): SuperAgentRequestWithPerform {
		return convert_to_promise(request.get(path));
	},
};

export default wrapper;



