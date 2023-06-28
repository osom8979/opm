import {applyMixins} from './mixin';
import ApiBase from './base';
import ApiPublic from './mixins/public';
import type ApiOptions from './options';

class Api extends ApiBase {
  constructor(options?: ApiOptions) {
    super(options);
  }

  private static globalInstance?: Api;

  static get global(): Api {
    if (!Api.globalInstance) {
      Api.globalInstance = new Api();
    }
    return Api.globalInstance as Api;
  }
}

// eslint-disable-next-line @typescript-eslint/no-empty-interface
interface Api extends ApiPublic {}
applyMixins(Api, [ApiPublic]);

export default Api;
