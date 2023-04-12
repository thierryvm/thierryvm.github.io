document.addEventListener("DOMContentLoaded", function () {
    // Récupère toutes les barres de compétences dans le document
    const skillBars = document.querySelectorAll(".skill-bar");

    // Parcours chaque barre de compétence
    skillBars.forEach(function (skillBar) {
        // Récupère la valeur de la compétence depuis l'attribut data-skill
        const skillValue = skillBar.getAttribute("data-skill");

        // Anime la largeur de la barre de compétence en fonction de la valeur de la compétence
        animateSkillBar(skillBar, skillValue);

        // Affiche la valeur de la compétence en pourcentage à l'intérieur de la barre
        skillBar.querySelector("span").innerText = `${skillValue}%`;
    });

    // Fonction pour animer la largeur de la barre de compétence
    function animateSkillBar(skillBar, skillValue) {
        let width = 0;
        const animationSpeed = 20; // Augmentez cette valeur pour ralentir l'animation
        const interval = setInterval(function () {
            if (width >= skillValue) {
                clearInterval(interval);
            } else {
                width++;
                skillBar.style.width = `${width}%`;

                // Appliquez une couleur différente en fonction du niveau de compétence
                if (width <= 33) { // Compétences faibles (33% ou moins)
                    skillBar.style.backgroundColor = "var(--low-skill-color)";
                } else if (width <= 66) { // Compétences moyennes (entre 34% et 66%)
                    skillBar.style.backgroundColor = "var(--medium-skill-color)";
                } else { // Compétences élevées (67% ou plus)
                    skillBar.style.backgroundColor = "var(--high-skill-color)";
                }

                // Met à jour le texte du pourcentage à l'intérieur de la barre
                skillBar.querySelector("span").innerText = `${width}%`;
            }
        }, animationSpeed);
    }
});

const backToTop = document.getElementById("back-to-top");

window.addEventListener("scroll", () => {
    if (window.pageYOffset > 300) {
        backToTop.style.display = "block";
        backToTop.classList.add('show');
    } else {
        backToTop.style.display = "none";
        backToTop.classList.remove('show');
    }
});
