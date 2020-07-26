import './assets/style.less'
import * as Shared from 'shared'
import DomNode from 'components/DomNode'

class Application {
  constructor() {
    let SIGNAL_1 = 'SIGNAL_FIRST'
    let SIGNAL_2 = 'SIGNAL_SECOND'
    console.log('Welcome DomNode: ', new DomNode('greeting'))
    Shared.WireJS.add(this, SIGNAL_1, (data, wid) => {
      let wire = Shared.WireJS.get(null, null, null, wid).pop();
      console.log(`Wire > ${wid}: with1 data =`, data, wire.signal, wire)
    })
    Shared.WireJS.add(this, SIGNAL_2, (data, wid) => {
      let wire = Shared.WireJS.get(null, null, null, wid).pop();
      console.log(`Wire > ${wid}: with data =`, data, wire.signal, wire)
    })
    // let wireData = Wire.data('key2', 'value')
    // console.log('Welcome WireData: ', wireData)
    // console.log('Welcome WireData value: ', wireData.value)
    //
    Shared.WireJS.send(SIGNAL_1, 'Data_1_Attached')
    Shared.WireJS.send(SIGNAL_2, 'Data_2_Attached')
  }
}

new Application()
