document.addEventListener('DOMContentLoaded', () => {
    // 1. Fade in page content (Existing logic)
    const page = document.querySelector('.page-content');
    if (page) {
        page.classList.add('active');
    }

    // 2. Smooth transition for links (Existing logic)
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
    });

    // 3. Slideshow Logic (New logic for Index page)
    let slideIndex = 0;
    const slides = document.getElementsByClassName("slide");

    // Only run if slides exist on the current page
    if (slides.length > 0) {
        showSlides();
    }

    function showSlides() {
        // Hide all slides
        for (let i = 0; i < slides.length; i++) {
            slides[i].style.display = "none";  
        }
        
        // Increment index and reset if at the end
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