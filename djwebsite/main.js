// Fade in page content
document.addEventListener('DOMContentLoaded', () => {
    const page = document.querySelector('.page-content');
    page.classList.add('active');

    // Smooth transition for links
    const links = document.querySelectorAll('nav a');
    links.forEach(link => {
        link.addEventListener('click', e => {
            e.preventDefault();
            page.classList.remove('active');
            const href = link.getAttribute('href');
            setTimeout(() => {
                window.location = href;
            }, 500); // matches CSS transition
        });
    });
});
