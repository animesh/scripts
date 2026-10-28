(async () => {
    const searchTerm = ".pdf".toLowerCase();
    console.log(`Scanning library for books matching: "${searchTerm}"...`);
    
    const elements = document.querySelectorAll('*');
    let matchedCount = 0;

    for (const el of elements) {
        if (el.innerText && el.innerText.toLowerCase().includes(searchTerm)) {
            const menuBtn = el.querySelector('button[aria-label*="Action"], button[aria-label*="More"], button[aria-label*="Menu"], button[aria-id]');
            if (menuBtn && !el.dataset.processed) {
                el.dataset.processed = "true";
                matchedCount++;
                console.log(`[MATCH] Clicking menu for item...`);
                menuBtn.click();
                
                await new Promise(r => setTimeout(r, 600));
                
                // Click the delete/remove option in the dropdown
                const options = document.querySelectorAll('[role="menuitem"], span, div');
                let deleteTriggered = false;
                for (const opt of options) {
                    const text = opt.innerText.trim().toLowerCase();
                    if (text === 'delete from library' || text === 'remove from library' || text === 'delete uploaded book' || text === 'hide') {
                        opt.click();
                        deleteTriggered = true;
                        console.log(`-> Successfully triggered deletion option.`);
                        break;
                    }
                }
                
                if (deleteTriggered) {
                    // Wait for the confirmation popup to appear
                    await new Promise(r => setTimeout(r, 600));
                    
                    // Find and click the 'OK' button on the confirmation dialog
                    const buttons = document.querySelectorAll('button, span');
                    for (const btn of buttons) {
                        if (btn.innerText.trim() === 'OK') {
                            btn.click();
                            console.log(`-> Confirmed deletion on popup.`);
                            break;
                        }
                    }
                }
                
                await new Promise(r => setTimeout(r, 800));
            }
        }
    }
    console.log(`Finished scan. Processed matches: ${matchedCount}`);
})();