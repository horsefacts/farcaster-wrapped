document.addEventListener("DOMContentLoaded", function() {
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

  const main = document.querySelector("main");
  const seed = parseInt(main.dataset.seed, 10);
  const random = makeRandom(seed);

  let g = getRandomInt(4, random);

  let width = getSize();
  let height = getSize();

  let scale = height / 720;

  let gridSize = g == 4 ? 20 : g == 3 ? 40 : g == 2 ? 60 : g == 1 ? 80 : 120;

  let pathPoints = [];
  let numSquares = 200;
  let totalPoints = 100;

  var background_color = main.dataset.color;

  const canvas = document.createElement("canvas");
  const container = document.getElementById("c");
  container.classList.remove("p");
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

  cols = width / (gridSize * scale);
  rows = height / (gridSize * scale);

  var v1x = random()
  var v1y = random()
  var qv1x = random()
  var qv1y = random()
  var qv2x = random()
  var qv2y = random()
  var bv1x = random()
  var bv1y = random()
  var bv2x = random()
  var bv2y = random()
  var bv3x = random()
  var bv3y = random()

  let v1 = { x: v1x * 360 * scale, y: v1y * 360 * scale };
  let qv1 = { x: qv1x * 1000 * scale, y: qv1y * 1000 * scale };
  let qv2 = { x: qv2x * 500 * scale, y: qv2y * 1000 * scale + 500 * scale };
  let bv1 = { x: bv1x * 1150 * scale - 150 * scale, y: bv1y * 1000 * scale, };
  let bv2 = { x: bv2x * 1000 * scale, y: bv2y * 1000 * scale };
  let bv3 = { x: bv3x * 1150 * scale - 150 * scale, y: bv3y * 1000 * scale + 500 * scale, };

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
    ctx.canvas.width = getSize();
    ctx.canvas.height = getSize();
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

  function animate() {
    frameCount++;
    draw();
    setTimeout(() => requestAnimationFrame(animate), 25);
  }

  function resize() {
    width = getSize();
    height = getSize();
    scale = height / 720;  // Recalculate scale

    // Recalculate grid size
    gridSize = g == (4 * scale) ? (20 * scale) : g == 3 ? (40 * scale) : g == 2 ? (60 * scale) : g == 1 ? (80 * scale) : (120 * scale);

    // Update canvas size
    ctx.canvas.width = width;
    ctx.canvas.height = height;

    // Recalculate positions
    let v1 = { x: v1x * 360 * scale, y: v1y * 360 * scale };
    let qv1 = { x: qv1x * 1000 * scale, y: qv1y * 1000 * scale };
    let qv2 = { x: qv2x * 500 * scale, y: qv2y * 1000 * scale + 500 * scale };
    let bv1 = { x: bv1x * 1150 * scale - 150 * scale, y: bv1y * 1000 * scale, };
    let bv2 = { x: bv2x * 1000 * scale, y: bv2y * 1000 * scale };
    let bv3 = { x: bv3x * 1150 * scale - 150 * scale, y: bv3y * 1000 * scale + 500 * scale, };


    // Recalculating pathPoints
    pathPoints = [];
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
  }

  // Add the event listener for window resize
  window.addEventListener('resize', resize);

  animate();
});
