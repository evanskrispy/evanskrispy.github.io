document.addEventListener('DOMContentLoaded', () => {
    // 1. Fade in page content
    const page = document.querySelector('.page-content');
    if (page) {
        // Small timeout ensures the browser has time to register the initial opacity: 0
        setTimeout(() => {
            page.classList.add('active');
        }, 100);
    }

    // 2. Smooth transition for links
    const links = document.querySelectorAll('nav a');
    links.forEach(link => {
        link.addEventListener('click', e => {
            const href = link.getAttribute('href');
            
            // Only apply transition if it's an internal link
            if (href && !href.startsWith('#')) {
                e.preventDefault();
                if (page) {
                    page.classList.remove('active');
                }
                setTimeout(() => {
                    window.location = href;
                }, 500); // Matches your CSS transition time
            }
        });

    // 3. Slideshow Logic
    let slideIndex = 0;
    // Define slides globally within this scope so showSlides can see them
    const slides = document.getElementsByClassName("slide");

    if (slides.length > 0) {
        showSlides();

    function showSlides() {
        // Hide all slides
        for (let i = 0; i < slides.length; i++) {
            slides[i].style.display = "none";  
        }
        
        slideIndex++;
        if (slideIndex > slides.length) {
            slideIndex = 1;
        }    
        
        // Show the current slide
        slides[slideIndex - 1].style.display = "flex";  
        
        // Change image every 5 seconds
        setTimeout(showSlides, 5000); 
    }
});