import './assets/style.less'
import Wire from 'Wire'
import DomNode from 'components/DomNode'

class Application {
  constructor() {
    let SIGNAL_1 = 'SIGNAL_FIRST'
    let SIGNAL_2 = 'SIGNAL_SECOND'
    Wire.add(this, SIGNAL_1, (hash, data) => {
      let wire = Wire.get(null, null, null, hash).pop();
      console.log(`Wire > ${hash}: with data =`, data, wire.signal, wire)
    })
    Wire.add(this, SIGNAL_2, (hash, data) => {
      let wire = Wire.get(null, null, null, hash).pop();
      console.log(`Wire > ${hash}: with data =`, data, wire.signal, wire)
    })
    let wireData = Wire.data('key2', 'value')
    console.log('Welcome DomNode: ', new DomNode('greeting'))
    console.log('Welcome WireData: ', wireData)
    console.log('Welcome WireData value: ', wireData.value)
    
    Wire.send(SIGNAL_1, 'Data_1_Attached')
    Wire.send(SIGNAL_2, 'Data_2_Attached')
  }
}

new Application()
