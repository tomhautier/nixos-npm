import _ from 'lodash';


const obj= Object.freeze({
  type: 'WORLD',
  coordinate: {x:23, y: 45}
})


const getPropertyInObj = () => _.get(obj, 'coordinate.x');

console.log({properties:getPropertyInObj()})