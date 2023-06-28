export class UnsupportedOperationError extends Error {
  constructor(message?: string) {
    super(message || 'Unsupported Operation Error');
  }
}

export class IllegalArgumentError extends Error {
  constructor(message?: string) {
    super(message || 'Illegal Argument Error');
  }
}

export class TimeoutError extends Error {
  constructor(message?: string) {
    super(message || 'Timeout Error');
  }
}

export class UninitializedError extends Error {
  constructor(message?: string) {
    super(message || 'Uninitialized Error');
  }
}

export class UninitializedServiceError extends UninitializedError {
  constructor(message?: string) {
    super(message || 'Uninitialized Service Error');
  }
}

export class RefreshTokenError extends Error {
  constructor(message?: string) {
    super(message || 'Refresh Token Error');
  }
}
