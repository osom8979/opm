import ApiOptions from './options';

class ApiBase {
  address?: string;
  verbose?: boolean;
  onReady?: () => void;

  constructor(options?: ApiOptions) {
    this.address = options?.address || document.location.origin;
    this.verbose = options?.verbose || false;
    this.onReady = options?.onReady;
  }

  init() {
    if (this.verbose) {
      console.debug('Initializing ...');
    }

    if (this.onReady) {
      this.onReady();
    }
  }
}

export default ApiBase;
