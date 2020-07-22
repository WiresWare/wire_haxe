import './assets/style.less'
import { Wire } from 'Wire'
import DomNode from 'components/DomNode'

class Application {
  constructor() {
    let SIGNAL = 'SIGNAL_FIRST'
    Wire.add(this, SIGNAL, (wire, data) => {
      console.log(`Wire > ${wire._signal}: with data =`, data, wire)
    })
    console.log('Welcome DomNode: ', new DomNode('greeting'));
    Wire.send(SIGNAL, 'DATA')
  }
}

new Application()
