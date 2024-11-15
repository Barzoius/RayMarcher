#include "Window.hpp"
#include "Shader.hpp"

#include "memory"




class Application
{
public:
    Application();
    ~Application();

    void Run();
    void OnEvent();

    bool OnWindowClose();

    inline Window* GetWindow() { return mWindow.get(); }

    //TestSquare test;


private:
    std::unique_ptr<Window> mWindow;
    bool mIsRunning = true;

    
};