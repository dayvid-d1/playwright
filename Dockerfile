FROM mcr.microsoft.com/playwright:jammy
RUN mkdir -p /ms-playwright/tests
COPY ./playwright/ /ms-playwright
WORKDIR /ms-playwright
VOLUME /ms-playwright/tests
EXPOSE 9323 
EXPOSE 8000
RUN sh -c "npm install && npx playwright install --with-deps"