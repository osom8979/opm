import {sha256hex} from './crypto';

describe('crypto', () => {
  test('sha256hex', () => {
    // command-line: `echo -n '0000' | sha256sum -t`
    expect(sha256hex('0000')).toEqual(
      '9af15b336e6a9619928537df30b2e6a2376569fcf9d7e773eccede65606529a0',
    );
  });
});
