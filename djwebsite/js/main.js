document.addEventListener('DOMContentLoaded', () => {
    // 1. Fade in page content logic goes here...

    // 2. Smooth transition for links
    const links = document.querySelectorAll('nav a');
    links.forEach(link => {
        link.addEventListener('click', e => {
            const href = link.getAttribute('href');
            
            if (href && !href.startsWith('#')) {
                e.preventDefault();
                // Transition logic...
                setTimeout(() => {
                    window.location = href;
                }, 500); 
            }
        }); // Correctly closes the click listener
    }); // Correctly closes the forEach loop

    // 3. Slideshow Logic
    let slideIndex = 0;
    const slides = document.getElementsByClassName("slide");

    if (slides.length > 0) {
        showSlides();
    } // Correctly closes the if statement

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
}); // Correctly closes the DOMContentLoaded listener