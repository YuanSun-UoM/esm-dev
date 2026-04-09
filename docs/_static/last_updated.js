document.addEventListener("DOMContentLoaded", function() {
    const el = document.getElementById("last-updated");
    if (el) {
        const lastModified = new Date(document.lastModified);
        el.textContent = lastModified.toLocaleDateString('en-GB', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    }
});