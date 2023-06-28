// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function applyMixins(derivedConstructor: any, baseConstructors: any[]) {
  baseConstructors.forEach(baseConstructor => {
    Object.getOwnPropertyNames(baseConstructor.prototype).forEach(name => {
      if (name !== 'constructor') {
        Object.defineProperty(
          derivedConstructor.prototype,
          name,
          Object.getOwnPropertyDescriptor(baseConstructor.prototype, name) ||
            Object.create(null),
        );
      }
    });
  });
}
