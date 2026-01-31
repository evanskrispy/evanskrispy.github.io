document.addEventListener('DOMContentLoaded', () => {
    // 1. Fade in page content
    const page = document.querySelector('.page-content');
    if (page) {
        setTimeout(() => {
            page.classList.add('active');
        }, 100);
    }

    // 2. Smooth transition for links
    const links = document.querySelectorAll('nav a');
    links.forEach(link => {
        link.addEventListener('click', e => {
            const href = link.getAttribute('href');
            
            if (href && !href.startsWith('#')) {
                e.preventDefault();
                if (page) {
                    page.classList.remove('active');
                }
                setTimeout(() => {
                    window.location = href;
                }, 500); 
            }
        });
    });

    // 3. Slideshow Logic
    let slideIndex = 0;
    const slides = document.getElementsByClassName("slide");

    if (slides.length > 0) {
        showSlides();
    }

    function showSlides() {
        for (let i = 0; i < slides.length; i++) {
            slides[i].style.display = "none";  
        }
        
        slideIndex++;
        if (slideIndex > slides.length) {
            slideIndex = 1;
        }    
        
        slides[slideIndex - 1].style.display = "flex";  
        setTimeout(showSlides, 5000); 
    }
});