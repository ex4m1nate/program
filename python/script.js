// Get the navigation links
const navLinks = document.querySelectorAll('nav a');

// Loop through each link
navLinks.forEach(link => {
  // Check if the link points to the current page
    if (link.href === window.location.href) {
        // Add the "active" class to the link
        link.classList.add('active');
    }
});

// Scroll to section on link click
navLinks.forEach(link => {
    link.addEventListener('click', e => {
        e.preventDefault();
        const target = document.querySelector(link.getAttribute('href'));
        window.scrollTo({
            top: target.offsetTop,
            behavior: 'smooth'
        });
    });
});

// Toggle mobile menu
const mobileMenu = document.querySelector('.mobile-menu');
const navList = document.querySelector('nav ul');

mobileMenu.addEventListener('click', () => {
    navList.classList.toggle('show');
});