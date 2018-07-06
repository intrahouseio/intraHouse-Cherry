/** 
* @name Виртуальный датчик темноты (рассвет-закат) 
* @desc 0 - светло, 1 - темно
* Запускается на старте сервера
*/
const darkness = Device("SensorD"); 

const script = {
    boot() {
      return true;
    },
    
    start() {
      let now = Date.now();
      let sunrise = this.getSysTime('sunrise','today');
      let sunset = this.getSysTime('sunset','today');
       
      let val = (now < sunrise || now > sunset) ? 1 : 0;
      this.assign(darkness, 'dval', val);
      
      let nextrise = (now < sunrise) ? sunrise : this.getSysTime('sunrise','tomorrow');
      this.startTimer('sunrise', nextrise, 'onSunrise');
      
      let nextset = (now < sunset) ? sunset : this.getSysTime('sunset','tomorrow');
      this.startTimer('sunset', nextset, 'onSunset');
    },
    
    onSunrise() {
       this.assign(darkness, 'dval', 0);
       this.startTimer('sunrise', this.getSysTime('sunrise','tomorrow'), 'onSunset');
    },
     
     onSunset() {
       this.assign(darkness, 'dval', 1);
       this.startTimer('sunset', this.getSysTime('sunset','tomorrow'), 'onSunset');
    }
    
    
};
