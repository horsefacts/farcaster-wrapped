document.addEventListener("DOMContentLoaded", function () {
  function makeRandom(seed) {
    const k = 16807;
    const mod = 2147483647;
    let s = seed % mod;

    const next = () => {
      s = (s * k) % mod;
      return s / mod;
    };
    return next;
  }

  function getRandomInt(max, random) {
    return Math.floor(random() * max);
  }

  function getSize() {
    return window.innerHeight >= window.innerWidth
      ? window.innerWidth
      : window.innerHeight;
  }

  function initializeCanvas(canvas) {
    const width = getSize();
    const height = getSize();

    const scale = height / 720;

    const gridSize =
      g == 4 ? 20 : g == 3 ? 40 : g == 2 ? 60 : g == 1 ? 80 : 120;
    canvas.width = width;
    canvas.height = height;

    return { width, height, scale, gridSize };
  }

  const wrapper = document.getElementById("w");
  wrapper.className = "";

  const main = document.querySelector("main");
  const seed = parseInt(main.dataset.seed, 10);
  const random = makeRandom(seed);

  let g = getRandomInt(4, random);

  let pathPoints = [];
  let numSquares = 200;
  let totalPoints = 100;

  let x = getRandomInt(6, random);

  var background_color =
    x == 5
      ? "#524D61"
      : x == 4
      ? "#261356"
      : x == 3
      ? "#8A63D2"
      : x == 2
      ? "#3F1E94"
      : x == 1
      ? "#BAB3CD"
      : "#8A63D2";

  const canvas = document.createElement("canvas");
  let { width, height, scale, gridSize } = initializeCanvas(canvas);
  const container = document.getElementById("c");
  container.appendChild(canvas);
  const ctx = canvas.getContext("2d");

  function lerp(start, end, amt) {
    return (1 - amt) * start + amt * end;
  }

  function quadraticPoint(startX, controlX, endX, startY, controlY, endY, t) {
    let x = lerp(lerp(startX, controlX, t), lerp(controlX, endX, t), t);
    let y = lerp(lerp(startY, controlY, t), lerp(controlY, endY, t), t);
    return { x, y };
  }

  function bezierPoint(p0, p1, p2, p3, t) {
    let cX = 3 * (p1 - p0),
      bX = 3 * (p2 - p1) - cX,
      aX = p3 - p0 - cX - bX;

    let cY = 3 * (p1 - p0),
      bY = 3 * (p2 - p1) - cY,
      aY = p3 - p0 - cY - bY;

    let x = aX * Math.pow(t, 3) + bX * Math.pow(t, 2) + cX * t + p0;
    let y = aY * Math.pow(t, 3) + bY * Math.pow(t, 2) + cY * t + p0;

    return { x, y };
  }

  let v1 = { x: random() * 360 * scale, y: random() * 360 * scale };
  let qv1 = { x: random() * 1000 * scale, y: random() * 1000 * scale };
  let qv2 = {
    x: random() * 500 * scale,
    y: random() * 1000 * scale + 500 * scale,
  };
  let bv1 = {
    x: random() * 1150 * scale - 150 * scale,
    y: random() * 1000 * scale,
  };
  let bv2 = { x: random() * 1000 * scale, y: random() * 1000 * scale };
  let bv3 = {
    x: random() * 1150 * scale - 150 * scale,
    y: random() * 1000 * scale + 500 * scale,
  };

  for (let i = 0; i <= totalPoints / 3; i++) {
    let t = i / (totalPoints / 3);
    let point = quadraticPoint(v1.x, qv1.x, qv2.x, v1.y, qv1.y, qv2.y, t);
    pathPoints.push(point);
  }

  for (let i = 0; i <= totalPoints / 3; i++) {
    let t = i / (totalPoints / 3);
    let x = bezierPoint(qv2.x, bv1.x, bv2.x, bv3.x, t);
    let y = bezierPoint(qv2.y, bv1.y, bv2.y, bv3.y, t);
    pathPoints.push({ x, y });
  }

  for (let i = 0; i <= totalPoints / 3; i++) {
    let t = i / (totalPoints / 3);
    let x = lerp(bv3.x, v1.x, t);
    let y = lerp(bv3.y, v1.y, t);
    pathPoints.push({ x, y });
  }

  for (let i = 0; i <= totalPoints / 2; i++) {
    let t = i / (totalPoints / 2);
    let x = bezierPoint(qv2.x, bv1.x, bv2.x, bv3.x, t);
    let y = bezierPoint(qv2.y, bv1.y, bv2.y, bv3.y, t);
    pathPoints.push({ x, y });
  }

  let frameCount = 0;

  function draw() {
    let { width, height, gridSize } = initializeCanvas(canvas);
    ctx.fillStyle = background_color;
    ctx.fillRect(0, 0, width, height);

    for (let i = 0; i < numSquares; i++) {
      let index =
        (frameCount - 1 + (i * totalPoints) / numSquares + pathPoints.length) %
        pathPoints.length;
      let pos = pathPoints[Math.floor(index)];

      let x = Math.floor(pos.x / gridSize) * gridSize;
      let y = Math.floor(pos.y / gridSize) * gridSize;

      let hue = (i * (360 / 180)) % 360;
      ctx.fillStyle = `hsl(${hue}, 100%, 50%)`;
      ctx.fillRect(x + 10, y, gridSize, gridSize);
    }
  }

  window.addEventListener("resize", () => {
    ({ width, height, scale, gridSize } = initializeCanvas(canvas));
    console.log("uhhhhh............");
  });

  function animate() {
    frameCount++;
    draw();
    setTimeout(() => requestAnimationFrame(animate), 25);
  }

  animate();
});
