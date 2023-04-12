document.querySelector('.download-button').addEventListener('click', function (e) {
    e.preventDefault();
    const cvElement = document.querySelector('body');

    html2canvas(cvElement).then(function (canvas) {
        const imgData = canvas.toDataURL('image/png');
        const pdf = new jsPDF('p', 'mm', 'a4');
        const width = pdf.internal.pageSize.getWidth();
        const height = pdf.internal.pageSize.getHeight();
        const ratio = width / canvas.width;
        pdf.addImage(imgData, 'PNG', 0, 0, canvas.width * ratio, canvas.height * ratio);
        pdf.save('Thierry_Vanmeeteren_CV.pdf');
    });
});
