#include "App.hpp"

#include <vector>

Application::Application()
{
    mWindow = std::make_unique<Window>(800, 600, "RayMarcher");


    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "GLAD FAILED";
    }


    glEnable(GL_DEPTH_TEST);
}

Application::~Application()
{

}



void Application::OnEvent()
{
    if (glfwGetKey(mWindow->GetWindow(), GLFW_KEY_ESCAPE) == GLFW_PRESS)
    {
        glfwSetWindowShouldClose(mWindow->GetWindow(), true);
    }

    if (glfwGetKey(mWindow->GetWindow(), GLFW_KEY_P) == GLFW_PRESS)
    {
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    }

}


void Application::Run()
{
    GLuint VAO;
    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);

    ShaderSuite ss = ShaderSuite(std::initializer_list<std::pair<std::string_view, Shader::ShaderType>>{
        {"Shader/BaseVertexShader.glsl", Shader::ShaderType::VERTEX},
        { "Shader/RayMarching.glsl", Shader::ShaderType::FRAGMENT },
    });
    

    glm::vec2 res;
    glm::vec2 mouse;

    double xpos, ypos;
    int wndWidth, wndHeight;

    while (!glfwWindowShouldClose(mWindow->GetWindow()))
    {

        mWindow->ProcessInput();

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);



        glfwGetCursorPos(mWindow->GetWindow(), &xpos, &ypos);
        glfwGetWindowSize(mWindow->GetWindow(), &wndWidth, &wndHeight);

        float NDC_X = (xpos / wndWidth) * 2.0f - 1.0f;
        float NDC_Y = 1.0f - (ypos / wndHeight) * 2.0f;


        res = glm::vec2(wndWidth, wndHeight);
        mouse = glm::vec2(NDC_X, NDC_Y);

        ss.use();
        ss.setVec2("uResolution", res);
        ss.setVec2("uDirection", mouse);


        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 6);


        mWindow->OnUpdate();
    }

    glDeleteVertexArrays(1, &VAO);

}

bool Application::OnWindowClose()
{
    mIsRunning = false;
    return true;
}