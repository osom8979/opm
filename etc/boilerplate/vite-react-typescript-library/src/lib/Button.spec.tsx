import {render, screen} from '@testing-library/react';
import {Button} from './Button';

describe('Button', () => {
  const props = {
    caption: 'test-button-title',
  };

  it('Render', () => {
    render(<Button {...props} />);

    const root = screen.getByTestId('root');
    const caption = screen.getByTestId('caption');

    expect(root).toBeDefined();
    expect(caption).toBeDefined();
  });
});
