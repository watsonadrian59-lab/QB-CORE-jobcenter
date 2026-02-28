const container = document.getElementById("container");
const jobList = document.getElementById("jobList");
const closeBtn = document.getElementById("closeBtn");
const searchInput = document.getElementById("searchInput");

let currentJob = null;
let allJobs = [];

const jobIcons = {
    police: "fa-shield-halved",
    ambulance: "fa-truck-medical",
    mechanic: "fa-wrench",
    taxi: "fa-taxi",
    garbage: "fa-trash",
    trucker: "fa-truck",
    default: "fa-briefcase"
};

window.addEventListener("message", function(event) {
    const data = event.data;

    if (data.action === "open") {
    container.style.display = "block";
    canvas.style.display = "block"; // show particles only in menu
    currentJob = data.currentJob || null; // <-- set job from server
}

if (data.action === "close") {
    container.style.display = "none";
    canvas.style.display = "none"; // hide particles when closed
}

    if (data.action === "loadJobs") {
        allJobs = data.jobs;
        renderJobs(allJobs);
    }
});

function renderJobs(jobs) {
    jobList.innerHTML = "";

    jobs.forEach(job => {
        const icon = jobIcons[job.name] || jobIcons.default;
        const isEmployed = job.name === currentJob;

        const card = document.createElement("div");
        card.className = "job-card";

        card.innerHTML = `
    <div class="job-title">
        <h3><i class="fas ${icon}"></i> ${job.label}</h3>
        ${isEmployed ? '<span class="employed">Currently Employed</span>' : ''}
    </div>
    <p>Starting Pay: $${job.payment} per paycheck</p>

    <div class="job-actions">
        ${!isEmployed ? '<button class="apply-btn">Apply</button>' : ''}
        ${isEmployed ? '<button class="quit-btn">Quit Job</button>' : ''}
    </div>
`;

        if (!isEmployed) {
            card.querySelector(".apply-btn").addEventListener("click", function() {
    fetch(`https://${GetParentResourceName()}/apply`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ job: job.name })
    }).then(() => {
        // Update UI to reflect new job
        currentJob = job.name;
        renderJobs(allJobs);
    });
});
        }

        if (isEmployed) {
    card.querySelector(".quit-btn").addEventListener("click", function() {
        fetch(`https://${GetParentResourceName()}/quit`, {
            method: "POST",
            headers: { "Content-Type": "application/json" }
        }).then(() => {
            currentJob = null;
            renderJobs(allJobs);
        });
    });
}

        jobList.appendChild(card);
    });
}

searchInput.addEventListener("input", function() {
    const search = this.value.toLowerCase();
    const filtered = allJobs.filter(job =>
        job.label.toLowerCase().includes(search)
    );
    renderJobs(filtered);
});

closeBtn.addEventListener("click", function() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: "POST",
        headers: { "Content-Type": "application/json" }
    });
});

// PARTICLE BACKGROUND
const canvas = document.getElementById("particles");
const ctx = canvas.getContext("2d");

canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

let particles = [];

for (let i = 0; i < 60; i++) {
    particles.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        radius: Math.random() * 2 + 1,
        speed: Math.random() * 0.5 + 0.2
    });
}

function animateParticles() {
    if (canvas.style.display === "none") return; // stop drawing when hidden

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    particles.forEach(p => {
        p.y -= p.speed;
        if (p.y < 0) p.y = canvas.height;

        ctx.beginPath();
        ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
        ctx.fillStyle = "rgba(179,136,255,0.4)";
        ctx.fill();
    });

    requestAnimationFrame(animateParticles);
}

animateParticles();