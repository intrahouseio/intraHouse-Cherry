/** 
* @name Батареи по температуре АВТО 
* @desc Включение-выключение батареи по датчику температуры
*       Уставка на датчике температуры 
*/
const bat = Device("ActorD", "Батарея"); 

const dt = Device("SensorA", "Датчик температуры"); 

const script = {
  check() {
    return bat.auto && ( (bat.dval==0)&&(dt.aval <= dt.defval-0.5) || (bat.dval>0)&&(dt.aval >= dt.defval));
  },

  start() {
    if (bat.dval==0) {
      this.do(bat, "aon");
    } else {
      this.do(bat, "aoff");
    }
  }
};

