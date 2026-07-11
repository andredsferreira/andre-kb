import { utilsRandomInt } from './utils'

export function CountColorfull() {
  let count = 0
  const container = document.createElement('div')
  container.style.display = 'inline-block'
  container.style.margin = '10px'
  container.style.border = '2px solid black'
  container.style.textAlign = 'center'

  container.addEventListener('click', () => {
    let r = utilsRandomInt(0, 255)
    let g = utilsRandomInt(0, 255)
    let b = utilsRandomInt(0, 255)
    container.style.backgroundColor = `rgb(${r}, ${g}, ${b})`
  })

  const countDisplay = document.createElement('p')
  const countButton = document.createElement('button')

  countDisplay.innerText = '0'
  countButton.innerText = 'Increment'

  const increment = () => {
    count++
    countDisplay.innerText = count.toString()
  }

  countButton.addEventListener('click', increment)

  container.appendChild(countDisplay)
  container.appendChild(countButton)
  document.body.appendChild(container)
}