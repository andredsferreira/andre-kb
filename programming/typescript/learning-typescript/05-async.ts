/** 
 * Java is a single threaded language. To allow for asynchronous
 * programming it uses an event loop. In the event loop promises 
 * are executed last, this means that (bellow the function) the
 * console log will execute first.
 * Bellow i show the exact same function written without async/await
 * and with the async/await.
 */

function promiseRandomEvenNumber(): Promise<number> {
  return new Promise((resolve, reject) => {
    let a = Math.floor(Math.random() * 10 + 1);
    if (a % 2 == 0) {
      resolve(a);
    } else {
      reject(new Error('Number is not even'));
    }
  });
}

async function asyncRandomEvenNumber(): Promise<number> {
  let a = Math.floor(Math.random() * 10 + 1);
  if (a % 2 == 0) {
    return a
  } else {
    throw new Error('Number is not even')
  }
}

promiseRandomEvenNumber().then(res => console.log(res))
  .catch(err => console.log(err))

console.log('I will execute first.')

asyncRandomEvenNumber().then(res => console.log(res))
  .catch(err => console.log(err))

console.log('I\'m in second place.')