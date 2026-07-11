/**
 * When declaring always indicate the type;
 * When declaring and assigning the type is infered, no need to declare it;
 * 'undefined' and 'null' are also primitive values used in special ocasions;
 * 'number' can be an integer or a floating point value;
 */

export function primitiveTypes(): void {
  let a: number
  let b: string
  let c: boolean
  let d: bigint

  a = 22
  b = 'Hello, bro!'
  c = true
  d = 9007199254740991n

  console.log('Typescript primitive types:')
  console.log(`a=${a}\nb=${b}\nc=${c}\nd=${d}\n`)

  // These are infered to be of the type 'number' and 'string' respectively.
  let x = 2.1
  let y = 'My name is Andrew'

  console.log('Typescript can infer the type of variables:')
  console.log(typeof (x) + "\n" + typeof (y))
}