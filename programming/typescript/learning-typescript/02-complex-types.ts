/**
 * Arrays and Maps need to be initialized before they can be used;
 */

// Defining types with 'type' keyword
type Product = {
  name: string;
  price: number;
}

export function complexTypes(): void {
  // Arrays
  let a = [-0.5, 0.5, 1, 0];
  let b = ['Monday', 'Wednesday', 'Friday'];

  // Maps
  let c = new Map<number, string>([
    [1, 'John Doe'],
    [2, 'Alicia Wood'],
    [3, 'Jim Morrison']
  ]);

  console.log('Complex types: ');
  console.log(`a=${a}\nb=${b}\nc=${c}\n`);


  // When declaring and assigning you should specify the type
  let banana: Product = {
    name: 'Banana',
    price: 1.12
  }

  console.log('Product type: ' + banana);
}

export function fileringArray(): void {
  const cars: Product[] = [
    { name: 'Ford', price: 1200 },
    { name: 'Mitsubishi', price: 2100 },
    { name: 'Toyota', price: 2000 },
    { name: 'Wolkswagen', price: 3000 },
    { name: 'Fiat', price: 800 },
    { name: 'Honda', price: 1000 },
    { name: 'Nissan', price: 2000 },
    { name: 'Mercedes', price: 8000 },
  ]

  console.log('Cars: ')
  console.table(cars)

  const filteredCars: Product[] = cars.filter((c) => {
    return c.price >= 2000
  })

  console.log('Filtered cars: ')
  console.table(filteredCars)

}

fileringArray()