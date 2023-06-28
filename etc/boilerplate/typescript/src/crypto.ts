import {SHA256} from 'crypto-js';

export function sha256hex(message: string): string {
  return SHA256(message).toString();
}
