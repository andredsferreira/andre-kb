function randomNumberInInterval(min: number, max: number): number {
  if (typeof min !== 'number' || typeof max !== 'number') {
    throw new Error('Both arguments must be numbers');
  }
  if (min > max) {
    throw new Error('The minimum value must be less than or equal to the maximum value');
  }
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

console.log(`Random number function called: ${randomNumberInInterval(1, 10)}`);

function printingArrayNumbers(array: number[]): void {
  array.forEach((v, i) => console.log(`[${i}]=${v}`))
  console.log()
}

console.log('printingArrayNumbers(): ')
printingArrayNumbers([1, 23, 8, 64, -213])